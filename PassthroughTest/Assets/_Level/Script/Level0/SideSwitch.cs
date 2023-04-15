using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SideSwitch : MonoBehaviour
{
    [SerializeField] private GameObject ying;
    [SerializeField] private GameObject yang;

    private bool yingVisability = false;
    private bool yangVisability = true;

    private bool playerLeave = true;

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player" && playerLeave)
        {
            //yingVisability = !yingVisability;
            //yangVisability = !yangVisability;
            ying.SetActive(true);
            yang.SetActive(false);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Player" && playerLeave)
        {
            ying.SetActive(false);
            yang.SetActive(true);
        }
    }

    //private void OnCollisionEnter(Collision collision)
    //{
    //    Debug.Log("Collide!");
    //    if (collision.gameObject.tag == "Player")
    //    {
    //        yingVisability = !yingVisability;
    //        yangVisability = !yangVisability;
    //        ying.SetActive(yingVisability);
    //        yang.SetActive(yangVisability);
    //    }
    //}
}
