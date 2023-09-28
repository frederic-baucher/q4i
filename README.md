# q4i

## Reuse
How to integrate in an existing project ?
To first install or update an already installed extension, the command is the same :
- cd to the root of project and then ...
```bash
> quarto add frederic-baucher/q4i

Quarto extensions may execute code when documents are rendered. If you do not
trust the authors of the extension, we recommend that you do not install or
use the extension.
 ? Do you trust the authors of this extension (Y/n) » Yes
[>] Downloading
[>] Unzipping
    Found 1 extension.

The following changes will be made:
Q4i   [Update] 1.0.0 -> 1.0.1 (shortcode)
 ? Would you like to continue (Y/n) » Yes

[>] Extension installation complete.
Learn more about this extension at https://www.github.com/frederic-baucher/q4i
```

## Usage

### Imgur (remote image)
```{{< q4i 'https://imgur.com/LKAJgs7.png' 'Alexander' >}}```

### Unsplash (stored locally)
The file is supposed to be stored in ```./assets/img/unsplash```
```{{< q4i 'topsphere-media-utMdPdGDc8M-unsplash.png' 'A car fleet' >}}```
