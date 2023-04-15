using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class RevealText : MonoBehaviour
{
    [SerializeField] private GameObject text;
    [SerializeField] private string animationParameter;
    [SerializeField] private Animator characterAnimator;

    public void revealNextText()
    {
        gameObject.SetActive(false);
        text.SetActive(true);
        characterAnimator.SetBool(animationParameter, true);
    }

    public void EndTextAnimation()
    {
        characterAnimator.SetBool(animationParameter, true);
    }

}
