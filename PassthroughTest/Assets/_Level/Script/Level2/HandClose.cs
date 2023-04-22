using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HandClose : MonoBehaviour
{
    [SerializeField] private Animator patientAnimator;

    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.tag == "Hands")
        {
            patientAnimator.SetBool("HandClose", true);
        }
    }
}
