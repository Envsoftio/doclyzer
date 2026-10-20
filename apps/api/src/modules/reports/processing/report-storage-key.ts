/** The source object belongs to the account and the profile that owns its report. */
export function reportSourceStorageKey(
  userId: string,
  profileId: string,
  reportId: string,
  contentType: string,
): string {
  const extensions: Record<string, string> = {
    'application/pdf': 'pdf',
    'image/png': 'png',
    'image/jpeg': 'jpg',
  };
  const extension = extensions[contentType];
  if (!extension) throw new Error('Unsupported report source content type');
  return `reports/${userId}/${profileId}/${reportId}.${extension}`;
}
