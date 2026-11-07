<script setup lang="ts">
import { languages, supportedLanguage, type SupportedLanguage } from '~~/shared/languages'
defineProps<{ modelValue: string; disabled?: boolean; description?: boolean }>()
const emit = defineEmits<{ 'update:modelValue': [value: SupportedLanguage] }>()
const { t } = useI18n()
const id = useId()
function select(event: Event) {
  emit('update:modelValue', supportedLanguage((event.target as HTMLSelectElement).value))
}
</script>

<template>
  <div class="language-picker">
    <label :for="id">{{ description ? t('descriptionLanguage') : t('preferredLanguage') }}</label>
    <select :id="id" :value="modelValue" :disabled="disabled" :lang="modelValue" @change="select">
      <option v-for="language in languages" :key="language.code" :value="language.code" :lang="language.code">
        {{ language.name }}
      </option>
    </select>
  </div>
</template>

<style scoped>
.language-picker { display: grid; gap: 8px; min-width: 0; max-width: 100%; }
.language-picker label { font-weight: 700; }
.language-picker select { width: 100%; min-height: 48px; padding: 9px 14px; border: 1px solid #9eb9a8; border-radius: 10px; background: #fff; color: #245d49; font: inherit; }
.language-picker select:focus-visible { outline: 3px solid #bd8b39; outline-offset: 3px; }
.language-picker select:disabled { opacity: .6; cursor: wait; }
</style>
