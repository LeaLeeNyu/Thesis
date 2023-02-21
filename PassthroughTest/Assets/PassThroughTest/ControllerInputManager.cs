using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.Rendering.Universal;
using UnityEngine.XR;


public enum HandType
{
    Left,
    Right,
}

public class ControllerInputManager : MonoBehaviour
{
    public HandType handType;

    //Stores what kind of characteristics we’re looking for with our Input Device when we search for it later
    [HideInInspector] public InputDeviceCharacteristics inputDeviceCharacteristics;

    //Stores the InputDevice that we’re Targeting once we find it in InitializeHand()
    private InputDevice _targetDevice;
    private Animator _handAnimator;

    //Hand Model Name String
    [SerializeField] private string leftHandName;
    [SerializeField] private string rightHandName;

    public event UnityAction thumbnileClickE = delegate { };
    private bool thumbnileClick = false;

    void Start()
    {
        InitializeHand();
    }

    void Update()
    {
        //Since our target device might not register at the start of the scene, we continously check until one is found.
        if (!_targetDevice.isValid)
        {
            InitializeHand();
        }
        else
        {
            //Update functions
            JoystickPressed();
        }
    }

    private void InitializeHand()
    {
        GameObject spawnedHand;

        if (handType == HandType.Left)
        {
            inputDeviceCharacteristics = InputDeviceCharacteristics.Left | InputDeviceCharacteristics.Controller;
            spawnedHand = GameObject.Find(leftHandName);
        }
        else
        {
            inputDeviceCharacteristics = InputDeviceCharacteristics.Right | InputDeviceCharacteristics.Controller;
            spawnedHand = GameObject.Find(rightHandName);
        }


        List<InputDevice> devices = new List<InputDevice>();
        //Call InputDevices to see if it can find any devices with the characteristics we’re looking for
        InputDevices.GetDevicesWithCharacteristics(inputDeviceCharacteristics, devices);

        //Our hands might not be active and so they will not be generated from the search.
        //We check if any devices are found here to avoid errors.
        if (devices.Count > 0)
        {
            _targetDevice = devices[0];
            //_handAnimator = spawnedHand.GetComponent<Animator>();
        }
    }

    void JoystickPressed()
    {
        _targetDevice.TryGetFeatureValue(CommonUsages.primary2DAxisClick, out bool isClick);

        if(isClick && !thumbnileClick)
        {
            thumbnileClickE.Invoke();
            thumbnileClick = true;
        }
        else if(!isClick)
        {
            thumbnileClick = false;
        }
    }


}
