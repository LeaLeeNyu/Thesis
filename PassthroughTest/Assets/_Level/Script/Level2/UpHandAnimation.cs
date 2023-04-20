using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UpHandAnimation : MonoBehaviour
{
    [SerializeField] private Animator patientAnimator;
    [SerializeField] private string aniName;
    [SerializeField] private GameObject firstText;

    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.tag == "Player")
        {
            patientAnimator.SetBool(aniName, true);
            firstText.SetActive(true);
        }
    }
}
