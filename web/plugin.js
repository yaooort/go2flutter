// 确保加载 wasm_exec.js 文件

function loadWasm() {
    const wasmFile = 'assets/packages/go/web/libgocoresdk.wasm'; // 确保路径正确
    const go = new Go();  // Go runtime

    WebAssembly.instantiateStreaming(fetch(wasmFile), go.importObject)
        .then((result) => {
            console.log('WASM module loaded');
            go.run(result.instance);  // 启动 Go 运行时
            wasmLoaded = true;
        })
        .catch((err) => {
            console.error('Failed to load WASM module:', err);
        });
}
