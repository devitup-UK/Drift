import fs from 'fs';
import path from 'path';

export function getInjectedCSS(): Promise<string> {
  return new Promise((resolve, reject) => {
    const cssPath = path.join(__dirname, '../../main/assets/styles/adblock.css');
    fs.readFile(cssPath, 'utf-8', (err, data) => {
      if (err) {
        reject(err);
      } else {
        resolve(data);
      }
    });
  });
}
