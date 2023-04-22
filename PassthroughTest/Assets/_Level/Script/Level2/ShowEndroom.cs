using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class ShowEndroom : MonoBehaviour
{
    [SerializeField] private GameObject endRoom;

    public static UnityAction photoOpen = delegate { };

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player")
        {
            endRoom.SetActive(true);
            photoOpen.Invoke();
        }
    }
}
