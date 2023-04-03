using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PassthroughManager : MonoBehaviour
{
    [SerializeField] private OVRPassthroughLayer _passthroughLayer;

    private void OnEnable()
    {
        ControllerInputManager.thumbnileClickE += TogglePassthrough;  
    }

    private void OnDisable()
    {
        ControllerInputManager.thumbnileClickE -= TogglePassthrough;
    }

    void TogglePassthrough()
    {
        _passthroughLayer.hidden= !_passthroughLayer.hidden;
    }
}
