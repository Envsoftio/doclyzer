<script setup lang="ts">
type Candidate = { id:string; page:number; table:number; testRaw:string; resultRaw:string|null; unitRaw:string|null; rangeRaw:string|null; tableBox:[number,number,number,number]; pageWidth:number; pageHeight:number; reviewReasons:string[] }
type Review = { action:string; page?:number; testRaw:string; resultRaw:string|null; unitRaw:string|null; rangeRaw:string|null }
type Shadow = { status:string; candidates:Candidate[]; pageStatus:Array<{page:number;status:string;candidateCount:number}>; reviews:Record<string,Review>; applied:Record<string,string>; reviewVersion:number }
const props = defineProps<{reportId:string; contentType:string}>()
const emit = defineEmits<{applied:[]}>()
const { request, apiBase, token } = useConsumer()
const shadow = ref<Shadow|null>(null), error = ref(''), busy = ref(false), selected = ref<Candidate|null>(null)
const originalUrl = ref(''), inspected = ref(false), action = ref<'confirmed'|'corrected'|'unreadable'>('confirmed')
const form = reactive({testRaw:'', resultRaw:'', unitRaw:'', rangeRaw:''})
const missed = reactive({page:0,testRaw:'',resultRaw:'',unitRaw:'',rangeRaw:'',sourceInspected:false})
const isImage = computed(()=>props.contentType.startsWith('image/'))
const highlight = computed(()=>{
  if (!selected.value || !isImage.value || selected.value.page !== 0) return null
  const c=selected.value, [x1,y1,x2,y2]=c.tableBox
  return {left:`${100*x1/c.pageWidth}%`,top:`${100*y1/c.pageHeight}%`,width:`${100*(x2-x1)/c.pageWidth}%`,height:`${100*(y2-y1)/c.pageHeight}%`}
})
async function load(){try{shadow.value=await request<Shadow>(`/reports/${props.reportId}/vl-review`)}catch(cause){error.value=(cause as Error).message}}
onMounted(load)
async function openSource(){
  if(originalUrl.value)return
  busy.value=true
  try{const blob=await $fetch<Blob>(`${apiBase}/reports/${props.reportId}/file`,{responseType:'blob',headers:{Authorization:`Bearer ${token.value}`}});originalUrl.value=URL.createObjectURL(blob)}
  catch(cause){error.value=(cause as Error).message}finally{busy.value=false}
}
async function choose(candidate:Candidate){
  selected.value=candidate;inspected.value=false;action.value='confirmed'
  const saved=shadow.value?.reviews[candidate.id]
  Object.assign(form,{testRaw:saved?.testRaw??candidate.testRaw,resultRaw:saved?.resultRaw??candidate.resultRaw??'',unitRaw:saved?.unitRaw??candidate.unitRaw??'',rangeRaw:saved?.rangeRaw??candidate.rangeRaw??''})
  await openSource()
}
async function save(){
  if(!shadow.value||!selected.value||!inspected.value)return
  busy.value=true;error.value=''
  try{
    await request(`/reports/${props.reportId}/vl-review/${selected.value.id}`,{method:'PATCH',body:{expectedVersion:shadow.value.reviewVersion,action:action.value,sourceInspected:true,testRaw:form.testRaw,resultRaw:form.resultRaw||null,unitRaw:form.unitRaw||null,rangeRaw:form.rangeRaw||null}})
    await load();selected.value=null
  }catch(cause){error.value=(cause as Error).message;await load()}finally{busy.value=false}
}
async function addMissed(){
  if(!shadow.value||!missed.sourceInspected||!originalUrl.value)return
  busy.value=true;error.value=''
  try{
    await request(`/reports/${props.reportId}/vl-review/missed`,{method:'POST',body:{expectedVersion:shadow.value.reviewVersion,...missed,unitRaw:missed.unitRaw||null,rangeRaw:missed.rangeRaw||null}})
    await load();Object.assign(missed,{testRaw:'',resultRaw:'',unitRaw:'',rangeRaw:'',sourceInspected:false})
  }catch(cause){error.value=(cause as Error).message;await load()}finally{busy.value=false}
}
async function applyReviewed(id:string){
  if(!shadow.value)return
  busy.value=true;error.value=''
  try{
    await request(`/reports/${props.reportId}/vl-review/${encodeURIComponent(id)}/apply`,{method:'POST',body:{expectedVersion:shadow.value.reviewVersion}})
    await load();emit('applied')
  }catch(cause){error.value=(cause as Error).message;await load()}finally{busy.value=false}
}
onBeforeUnmount(()=>{if(originalUrl.value)URL.revokeObjectURL(originalUrl.value)})
</script>

<template>
  <p v-if="error" role="alert">Additional review: {{ error }}</p>
  <section v-if="shadow && shadow.status !== 'unavailable'" class="card">
    <h2>Additional table review</h2>
    <p class="muted">These PaddleOCR readings need source confirmation before they enter report results. Check the original before recording a review. VL outlines cover a table; raw OCR outlines cover a row.</p>
    <p v-if="shadow.status==='partial'" role="status">Some pages failed extraction; this report is incomplete.</p>
    <p v-if="!shadow.candidates.length">No table rows were identified for review.</p>
    <p v-for="[id, review] in Object.entries(shadow.reviews).filter(([id])=>id.startsWith('manual-'))" :key="id">Added from page {{ (review.page ?? 0)+1 }}: {{ review.testRaw }} — {{ review.resultRaw }} {{ review.unitRaw }} <button v-if="!shadow.applied[id]" type="button" :disabled="busy" @click="applyReviewed(id)">Add to report results</button><span v-else>In report results</span></p>
    <div class="review-grid">
      <div>
        <button v-for="candidate in shadow.candidates" :key="candidate.id" type="button" class="candidate" :class="{active:selected?.id===candidate.id}" @click="choose(candidate)">
          <span>{{ candidate.testRaw }}: <strong>{{ candidate.resultRaw }} {{ candidate.unitRaw }}</strong></span>
          <small>Page {{ candidate.page+1 }} · {{ shadow.applied[candidate.id] ? 'In report results' : shadow.reviews[candidate.id]?.action ?? 'Needs review' }}</small>
        </button>
      </div>
      <div v-if="selected" class="review-panel">
        <h3>Inspect page {{ selected.page+1 }}</h3>
        <div v-if="originalUrl && isImage" class="source-frame"><img :src="originalUrl" alt="Original report page" /><div v-if="highlight" class="highlight" :style="highlight" /></div>
        <iframe v-else-if="originalUrl" :src="originalUrl" title="Original report; inspect the selected page" />
        <p class="muted">Source region: {{ selected.table === 1000 ? 'OCR row' : 'VL table' }}. Check the test and value in the original page.</p>
        <form @submit.prevent="save">
          <label>Test<input v-model="form.testRaw" maxlength="256" /></label>
          <label>Value<input v-model="form.resultRaw" maxlength="512" /></label>
          <label>Unit<input v-model="form.unitRaw" maxlength="64" /></label>
          <label>Reference range<input v-model="form.rangeRaw" maxlength="256" /></label>
          <label>Review decision<select v-model="action"><option value="confirmed">Confirmed as shown</option><option value="corrected">Corrected from source</option><option value="unreadable">Unreadable</option></select></label>
          <label class="check"><input v-model="inspected" type="checkbox" /> I checked this row against the original page</label>
          <button :disabled="busy || !inspected || !!shadow.applied[selected.id]">Record review</button>
          <button v-if="shadow.reviews[selected.id]?.action !== 'unreadable' && shadow.reviews[selected.id] && !shadow.applied[selected.id]" type="button" class="secondary" :disabled="busy" @click="applyReviewed(selected.id)">Add reviewed row to report results</button>
          <p v-if="shadow.applied[selected.id]">This reviewed row is in report results. Use the normal correction form for later edits.</p>
        </form>
      </div>
    </div>
    <details><summary>Add a missed result from the original</summary>
      <button type="button" class="secondary" :disabled="busy" @click="openSource">Open original</button>
      <div v-if="originalUrl" class="missed-source"><img v-if="isImage" :src="originalUrl" alt="Original report" /><iframe v-else :src="originalUrl" title="Original report" /></div>
      <form @submit.prevent="addMissed">
        <label>Page<select v-model.number="missed.page"><option v-for="page in shadow.pageStatus" :key="page.page" :value="page.page">{{ page.page+1 }}</option></select></label>
        <label>Test<input v-model="missed.testRaw" required maxlength="256" /></label>
        <label>Value<input v-model="missed.resultRaw" required maxlength="512" /></label>
        <label>Unit<input v-model="missed.unitRaw" maxlength="64" /></label>
        <label>Reference range<input v-model="missed.rangeRaw" maxlength="256" /></label>
        <label><input v-model="missed.sourceInspected" type="checkbox" /> I checked this row against the original page</label>
        <button :disabled="busy || !missed.sourceInspected || !originalUrl">Record missed result</button>
      </form>
    </details>
  </section>
</template>

<style scoped>
.review-grid{display:grid;grid-template-columns:minmax(220px,1fr) minmax(300px,2fr);gap:1rem}.candidate{display:block;width:100%;text-align:left;margin:0 0 .4rem;padding:.6rem;border:1px solid #cad9ce;border-radius:.5rem;background:white}.candidate.active{border-color:#176b4c}.candidate small{display:block;color:#5b6f64}.review-panel label{display:block;margin:.5rem 0}.review-panel input:not([type=checkbox]),.review-panel select{display:block;width:100%}.source-frame{position:relative}.source-frame img{display:block;width:100%;height:auto}.highlight{position:absolute;border:3px solid #e37716;background:#e3771633;pointer-events:none}.review-panel iframe{width:100%;height:520px}.check{display:flex!important;gap:.5rem;align-items:center}@media(max-width:800px){.review-grid{grid-template-columns:1fr}}
.missed-source img{max-width:100%;max-height:600px}.missed-source iframe{width:100%;height:600px}
</style>
