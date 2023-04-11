using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

public class EndPoint : MonoBehaviour
{
    [SerializeField] private PlayableDirector endHandTimeline;
    [SerializeField] private GameObject endHandModel;

    private void OnCollisionEnter(Collision collision)
    {
        Debug.Log("Collision");

        if(collision.gameObject.tag == "Player")
        {
            endHandModel.SetActive(true);
            endHandTimeline.Play();
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        Debug.Log("Trigger");

        if (other.gameObject.tag == "Player")
        {
            endHandModel.SetActive(true);
            endHandTimeline.Play();
        }
    }
}
