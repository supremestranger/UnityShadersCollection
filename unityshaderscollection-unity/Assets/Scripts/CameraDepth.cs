using UnityEngine;

sealed class CameraDepth : MonoBehaviour
{
    private void Awake()
    {
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
    }
}