# Tetris99s Client

## Setup

### Install NVM and Node

NVM is a morden Node version manager that allows you to quickly install and use different versions of node via the command line.

- Linux/MacOS
    - Please follow the following [instructions](https://github.com/nvm-sh/nvm#installing-and-updating) for installing NVM.
- Windows
    > If you insatll the environment in wsl, please follow instructions in `Linux/MacOS`
    - Please download the latest version of NVM from [here](https://github.com/coreybutler/nvm-windows/releases).

### Install project dependencies

Run the following command to setup.

```sh
npm install
```

### Develop

> There is a known caching [issue](https://github.com/jetli/create-yew-app/issues/13) for parcel bundler on windows, the hot reload module would not work properly. Please use [wsl](https://docs.microsoft.com/en-us/windows/wsl/install) if you are using Windows.

Builds the project and opens it in a new browser tab. Auto-reloads when the project changes.

```sh
npm start
```

### Build app in release mode

Builds the project and places it into the `dist` folder.

```sh
npm run build
```

### Test

Runs the following command to run rust unit tests

```sh

npm test
```
