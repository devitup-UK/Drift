import type { IHistoryEntry } from "../interfaces/IHistoryEntry";
import type Tab from "../Tab";

export type DriftDatabase = {
  tabs: Tab[];
  activeTabId?: string | null;
  history: IHistoryEntry[];
};
