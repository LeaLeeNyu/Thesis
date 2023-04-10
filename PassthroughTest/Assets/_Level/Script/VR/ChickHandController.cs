using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.XR;


public enum Hand
{
    Left,
    Right,
}

public class ChickHandController : MonoBehaviour
{
    #region HandInitialParameter
    public Hand handType;
    //Stores what kind of characteristics we¡¯re looking for with our Input Device when we search for it later
    [HideInInspector] public InputDeviceCharacteristics inputDeviceCharacteristics;
    //Stores the InputDevice that we¡¯re Targeting once we find it in InitializeHand()
    protected InputDevice _targetDevice;
    //Hand Model Name String
    [SerializeField] private string leftHandName;
    [SerializeField] private string rightHandName;
    #endregion

    public Animator chickAnimator;

    private void InitializeHand()
    {
        GameObject spawnedHand;

        if (handType == Hand.Left)
        {
            inputDeviceCharacteristics = InputDeviceCharacteristics.Left | InputDeviceCharacteristics.Controller;
            spawnedHand = GameObject.Find(leftHandName + "(Clone)");
        }
        else
        {
            inputDeviceCharacteristics = InputDeviceCharacteristics.Right | InputDeviceCharacteristics.Controller;
            spawnedHand = GameObject.Find(rightHandName + "(Clone)");
        }


        List<InputDevice> devices = new List<InputDevice>();
        //Call InputDevices to see if it can find any devices with the characteristics we are looking for
        InputDevices.GetDevicesWithCharacteristics(inputDeviceCharacteristics, devices);

        //Our hands might not be active and so they will not be generated from the search.
        //We check if any devices are found here to avoid errors.
        if (devices.Count > 0)
        {

            _targetDevice = devices[0];
            //_handAnimator = spawnedHand.GetComponent<Animator>();
        }
    }

    private void Start()
    {
        InitializeHand();
        FindChickAnimator();
    }

    protected virtual void Update()
    {
        if (!_targetDevice.isValid)
        {
            InitializeHand();
            FindChickAnimator();
        }
        else if (handType == Hand.Left)
        {
            TriggerPressed();
        }
    }

    private void FindChickAnimator()
    {
        if(handType== Hand.Right)
        {
            
        }
    }

    //Jump
    void TriggerPressed()
    {
        _targetDevice.TryGetFeatureValue(CommonUsages.triggerButton, out bool isPressed);

        //if player jumps, then the chick in the left hand jumps
        if(isPressed && handType == Hand.Left)
        {
            chickAnimator.SetBool("jump",true);
        }

    }

    //Walk
    void JoyStickValue()
    {
        _targetDevice.TryGetFeatureValue(CommonUsages.primary2DAxis, out Vector2 JoystickValue);
        // _targetDevice.TryGetFeatureValue(CommonUsages.triggerButton, out bool trigger);       

        //use left hand joysitick to scroll the canvas list
        if (handType == Hand.Left && (JoystickValue.y >= 0.1 || JoystickValue.x >= 0.1))
        {
            chickAnimator.SetBool("walk", true);
        }
        else
        {
            chickAnimator.SetBool("walk", false);
        }

    }


}
