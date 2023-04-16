using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.XR;


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

    //Hand Grab Animation
    [SerializeField] private Animator _animator;

    //Change material
    [SerializeField] private SkinnedMeshRenderer _skinnedMeshRenderer;
    [SerializeField] private Material _blackMaterial;
    [SerializeField] private Material _whiteMaterial;

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

    private void OnEnable()
    {
        SideSwitch.EnterBlack += WhiteToBlack;
        SideSwitch.EnterWhite += BlackToWhite;
    }

    private void OnDisable()
    {
        SideSwitch.EnterBlack -= WhiteToBlack;
        SideSwitch.EnterWhite -= BlackToWhite;
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
        else
        {
            UpdateHandPos();
        }
    }

    //Grab
    void UpdateHandPos()
    {
        if(_targetDevice.TryGetFeatureValue(CommonUsages.grip, out float grip))
        {
            _animator.SetFloat("Grab", grip);
        }
        else
        {
            _animator.SetFloat("Grab", 0);
        }
    }

    private void WhiteToBlack()
    {
        _skinnedMeshRenderer.material = _blackMaterial;
    }

    private void BlackToWhite()
    {
        _skinnedMeshRenderer.material = _whiteMaterial;
    }

}
