using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StartText : MonoBehaviour
{
    private bool startDialogue = false;
    [SerializeField] private GameObject firstText;
    [SerializeField] private GameObject secondText;
    [SerializeField] private string animationParameter;
    [SerializeField] private Animator characterAnimator;

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player" && !startDialogue)
        {
            startDialogue = true;
            firstText.SetActive(false);
            secondText.SetActive(true);
            characterAnimator.SetBool(animationParameter, true);
        }
    }
}
