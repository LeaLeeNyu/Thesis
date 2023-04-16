using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class SideSwitch : MonoBehaviour
{
    [SerializeField] private GameObject ying;
    [SerializeField] private GameObject yang;

    private bool yingVisability = false;
    private bool yangVisability = true;

    private bool playerLeave = true;

    public static UnityAction EnterBlack = delegate { };
    public static UnityAction EnterWhite = delegate { };

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player" && playerLeave)
        {
            ying.SetActive(true);
            yang.SetActive(false);

            EnterBlack.Invoke();
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Player" && playerLeave)
        {
            ying.SetActive(false);
            yang.SetActive(true);

            EnterWhite.Invoke();
        }
    }
}
