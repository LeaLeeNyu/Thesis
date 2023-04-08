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

public class XRHandController : MonoBehaviour
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

    public GameObject chick;

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
        //Call InputDevices to see if it can find any devices with the characteristics we¡¯re looking for
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
    }

    protected virtual void Update()
    {
        if (!_targetDevice.isValid)
        {
            InitializeHand();
        }
        else if (handType == Hand.Left)
        {
            TriggerPressed();
        }
    }

    //Jump
    void TriggerPressed()
    {
        _targetDevice.TryGetFeatureValue(CommonUsages.triggerButton, out bool isPressed);

        //if player jumps, then the chick in the left hand jumps
        if(isPressed && handType == Hand.Left)
        {

        }

    }

    //Walk
    void JoyStickValue()
    {
        _targetDevice.TryGetFeatureValue(CommonUsages.primary2DAxis, out Vector2 JoystickValue);
        // _targetDevice.TryGetFeatureValue(CommonUsages.triggerButton, out bool trigger);       

        //use left hand joysitick to scroll the canvas list
        //if(JoystickValue.y>= 0.8 && next)
        //{
        //    equipLastNum = equipListNum;
        //    equipListNum += 1;
        //    if (equipListNum > equipObjects.Length - 1)
        //        equipListNum = 0;

        //    equipObjects[equipLastNum].SetActive(false);
        //    equipObjects[equipListNum].SetActive(true);

        //    next = false;
        //}
        //else if(JoystickValue.y <= -0.8 && next)
        //{
        //    equipLastNum = equipListNum;
        //    equipListNum -= 1;
        //    if (equipListNum < 0)
        //        equipListNum = equipObjects.Length - 1;

        //    equipObjects[equipLastNum].SetActive(false);
        //    equipObjects[equipListNum].SetActive(true);

        //    next = false;
        //}
        //else if (JoystickValue.y == 0)
        //{
        //    //Only when the joystick reposition, the meun could switch to the next eqipment object again
        //    next = true;
        //}

    }


}
