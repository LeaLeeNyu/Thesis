using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SideSwitch : MonoBehaviour
{
    [SerializeField] private GameObject ying;
    [SerializeField] private GameObject yang;

    private bool yingVisability = false;
    private bool yangVisability = true;

    private void OnTriggerExit(Collider other)
    {
        if(other.tag == "Player")
        {
            yingVisability = !yingVisability;
            yangVisability = !yangVisability;
            ying.SetActive(yingVisability);
            yang.SetActive(yangVisability);
        }
    }

    private void OnCollisionExit(Collision collision)
    {
        Debug.Log("Collide!");
        if (collision.gameObject.tag == "Player")
        {
            yingVisability = !yingVisability;
            yangVisability = !yangVisability;
            ying.SetActive(yingVisability);
            yang.SetActive(yangVisability);
        }
    }
}
