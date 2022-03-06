using UnityEngine;

sealed class CameraDepth : MonoBehaviour {
    void Awake () {
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
    }
}
