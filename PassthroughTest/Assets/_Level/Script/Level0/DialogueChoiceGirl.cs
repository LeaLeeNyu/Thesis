using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DialogueChoiceGirl : MonoBehaviour
{
    [SerializeField] private GameObject diedDialogue;
    [SerializeField] private GameObject goDialogue;

    [SerializeField] private Animator girlAnimator;
    [SerializeField] private string aniName;

    public void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.tag == "Died")
        {
            diedDialogue.SetActive(true);
            girlAnimator.SetBool(aniName, true);
        }
        else if(other.gameObject.tag == "Go")
        {
            goDialogue.SetActive(true);
            girlAnimator.SetBool(aniName, true);
        }
    }
}
