export const TabType = {
  Standard: 'standard',
  Pinned: 'pinned',
  Folder: 'group',
} as const;

export type TabType = (typeof TabType)[keyof typeof TabType];
