using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TriggerHide : MonoBehaviour
{
    [SerializeField] private HideSteps hideSteps;

    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.tag == "Player")
        {
            hideSteps.HideTheCounting();
        }
    }
}
