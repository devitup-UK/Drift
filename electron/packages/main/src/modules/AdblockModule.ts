// AdblockModule.ts
import fs from 'fs';
import path from 'path';
import { session } from 'electron';
import { AppModule } from 'src/AppModule.js';
import { ModuleContext } from 'src/ModuleContext.js';
import { Window } from 'happy-dom';

interface ParsedFilters {
  network: string[];
  cosmetic: string[];
}

export class AdblockModule implements AppModule {
  // Get the current directory of this file
  private currentDir = path.dirname(import.meta.url.replace('file://', ''));
  private easyListPath = path.join(this.currentDir, '../assets/filters/easylist.txt');
  private ublockListPath = path.join(this.currentDir, '../assets/filters/ublock-filters.txt');
  private cssOutputPath = path.join(this.currentDir, '../../../packages/renderer/src/assets/styles/adblock.css');
  private window = new Window();
  private document = this.window.document;

  private networkRules: string[] = [];
  private cosmeticRules: string[] = [];

  async enable({app}: ModuleContext): Promise<void> {
      await app.whenReady();
      await this.loadFilters();
      this.setupNetworkBlocking();
  }

  async loadFilters(): Promise<void> {
    const easyList = fs.readFileSync(this.easyListPath, 'utf-8');
    const ublockList = fs.readFileSync(this.ublockListPath, 'utf-8');

    const easyParsed = this.parseFilterList(easyList);
    const ublockParsed = this.parseFilterList(ublockList);

    const rawNetworkRules = [...easyParsed.network, ...ublockParsed.network];
    this.networkRules = this.extractValidUrlPatterns(rawNetworkRules.join('\n'));
    this.cosmeticRules = [...easyParsed.cosmetic, ...ublockParsed.cosmetic];

    const css = this.getInjectedCSS();
    fs.writeFileSync(this.cssOutputPath, css, 'utf-8');
  }

  private parseFilterList(content: string): ParsedFilters {
    const lines = content.split('\n');
    const network: string[] = [];
    const cosmetic: string[] = [];

    for (const line of lines) {
      const trimmed = line.trim();
      if (
        trimmed === '' ||
        trimmed.startsWith('!') ||
        trimmed.startsWith('[')
      ) continue;

      if (trimmed.includes('##') || trimmed.includes('#@#')) {
        cosmetic.push(trimmed);
      } else {
        network.push(trimmed);
      }
    }
    return { network, cosmetic };
  }

  setupNetworkBlocking(): void {
    const patterns = this.networkRules;

    session.defaultSession.webRequest.onBeforeRequest(
      { urls: patterns },
      (details, callback) => {
        callback({ cancel: true });
      }
    );
  }

  getInjectedCSS(): string {
    return this.cosmeticRules
      .filter(rule => rule.includes('##'))
      .map(rule => {
        const [, selector] = rule.split('##');
        if (!selector || !this.isValidCssSelector(selector)) return null;
        return `${selector} { display: none !important; }`;
      })
      .filter(Boolean)
      .join('\n');
  }

  isValidCssSelector(selector: string): boolean {
     try {
        // Throws an error if the selector is invalid
        document.querySelector(selector);
        return true;
      } catch (e) {
        return false;
      }
  }

  extractValidUrlPatterns(filterText: string): string[] {
  const validPatterns: Set<string> = new Set();

  const lines = filterText.split('\n');
  for (const line of lines) {
    const trimmed = line.trim();

    // Skip unsupported or irrelevant rules
    if (
      trimmed.startsWith('!') ||     // comment
      trimmed.startsWith('@@') ||    // exception
      trimmed.includes('##') ||      // cosmetic
      trimmed.includes('#@#') ||
      trimmed.includes('$document')
    ) {
      continue;
    }

    // Only support domain-based rules like ||domain.com^
    if (trimmed.startsWith('||')) {
      // Remove everything after first '$' (modifiers like $script, $popup, etc.)
      const clean = trimmed.split('$')[0];

      // Extract domain
      const domain = clean.slice(2).split('^')[0];

      // Skip if malformed
      if (!domain || domain.includes('*') || domain.includes('**') || domain.includes('|') || domain.includes('/')) {
        continue;
      }

      // Add standard patterns
      validPatterns.add(`*://${domain}/*`);
      validPatterns.add(`http://${domain}/*`);
      validPatterns.add(`https://${domain}/*`);
    }
  }

  return Array.from(validPatterns);
}
}

export function setupAdblocking(...args: ConstructorParameters<typeof AdblockModule>) {
  return new AdblockModule(...args);
}
