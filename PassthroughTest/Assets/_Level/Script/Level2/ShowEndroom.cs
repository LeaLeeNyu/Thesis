using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShowEndroom : MonoBehaviour
{
    [SerializeField] private GameObject endRoom;
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player")
        {
            endRoom.SetActive(true);
        }
    }
}
