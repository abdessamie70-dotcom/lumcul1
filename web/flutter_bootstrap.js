{{flutter_js}}
{{flutter_build_config}}

const loadingContainer = document.getElementById('loading-container');

_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    
    if (loadingContainer) {
      loadingContainer.style.opacity = '0';
      setTimeout(function() {
        if (loadingContainer.parentNode) {
          loadingContainer.parentNode.removeChild(loadingContainer);
        }
      }, 400);
    }
    
    await appRunner.runApp();
  }
});
