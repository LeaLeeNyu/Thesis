using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PassthroughManager : MonoBehaviour
{
    [SerializeField] private OVRPassthroughLayer _passthroughLayer;
    [SerializeField] private ControllerInputManager _controllerInputManager;

    private void OnEnable()
    {
        _controllerInputManager.thumbnileClickE += TogglePassthrough;
    }

    private void OnDisable()
    {
        _controllerInputManager.thumbnileClickE -= TogglePassthrough;
    }

    void TogglePassthrough()
    {
        _passthroughLayer.hidden= !_passthroughLayer.hidden;
    }
}
