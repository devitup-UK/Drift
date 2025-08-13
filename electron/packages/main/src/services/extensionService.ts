import fs from 'fs';
import path from 'path';
import ChromeExtension from '../../../shared/models/ChromeExtension.js';

function getExtensionInfo(extensionId: string, extensionDir: string): ChromeExtension {
    // Find the actual extension folder (first subdirectory)
    const entries = fs.readdirSync(extensionDir, { withFileTypes: true });
    const extensionFolder = entries.find(entry => entry.isDirectory());

    if (!extensionFolder) {
        throw new Error(`No extension folder found in ${extensionDir}`);
    }

    const actualExtensionPath = path.join(extensionDir, extensionFolder.name);
    const manifestPath = path.join(actualExtensionPath, 'manifest.json');

    if (!fs.existsSync(manifestPath)) {
        throw new Error(`manifest.json not found in ${actualExtensionPath}`);
    }

    // Check file size to ensure it's not empty/still being written
    const stats = fs.statSync(manifestPath);
    if (stats.size === 0) {
        throw new Error(`manifest.json is empty (possibly still being written) in ${actualExtensionPath}`);
    }

    let manifest;
    try {
        const manifestContent = fs.readFileSync(manifestPath, 'utf8').trim();
        if (!manifestContent) {
            throw new Error(`manifest.json is empty in ${actualExtensionPath}`);
        }
        manifest = JSON.parse(manifestContent);
    } catch (error) {
        if (error instanceof SyntaxError) {
            throw new Error(`Invalid JSON in manifest.json at ${manifestPath}. File might still be writing. Error: ${error.message}`);
        }
        throw error;
    }

    // Validate required fields
    if (!manifest.name) {
        throw new Error(`manifest.json missing required 'name' field in ${actualExtensionPath}`);
    }

    // Handle the name
    let name = manifest.name;
    if (name.startsWith('__MSG_') && name.endsWith('__')) {
        const msgKey = name.replace(/^__MSG_/, '').replace(/__$/, '');
        const localeDir = path.join(actualExtensionPath, '_locales', manifest.default_locale || 'en');
        const messagesPath = path.join(localeDir, 'messages.json');
        if (fs.existsSync(messagesPath)) {
            try {
                const messages = JSON.parse(fs.readFileSync(messagesPath, 'utf8'));
                if (messages[msgKey] && messages[msgKey].message) {
                    name = messages[msgKey].message;
                }
            } catch (error) {
                console.warn(`Failed to parse locale messages for ${extensionFolder.name}`);
            }
        }
    }

    // Get smallest icon
    let iconBase64 = '';
    if (manifest.icons) {
        const iconSizes = Object.keys(manifest.icons).map(size => parseInt(size)).sort((a, b) => a - b);
        if (iconSizes.length > 0) {
            const smallestSize = iconSizes[0];
            const iconPath = path.join(actualExtensionPath, manifest.icons[smallestSize]);
            if (fs.existsSync(iconPath)) {
                try {
                    const iconBuffer = fs.readFileSync(iconPath);
                    iconBase64 = `data:image/png;base64,${iconBuffer.toString('base64')}`;
                } catch (error) {
                    console.warn(`Failed to read icon for ${extensionFolder.name}`);
                }
            }
        }
    }

    return new ChromeExtension(
        extensionId, // Fallback to folder name if no ID
        name,
        iconBase64
    );
}

export { getExtensionInfo }
