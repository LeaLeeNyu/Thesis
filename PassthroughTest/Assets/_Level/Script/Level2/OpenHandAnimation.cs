using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OpenHandAnimation : MonoBehaviour
{
    [SerializeField] private Animator handAnimator;

    private void OnEnable()
    {
        InteractableSelected.inteactableSelected += SwitchHandAnimation;
    }

    private void OnDisable()
    {
        InteractableSelected.inteactableSelected -= SwitchHandAnimation;
    }

    private void SwitchHandAnimation()
    {
        handAnimator.SetBool("OpenHand", true);
    }
}
