using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

public class EndPoint : MonoBehaviour
{
    [SerializeField] private PlayableDirector endHandTimeline;
    [SerializeField] private GameObject endHandModel;

    private void OnTriggerEnter(Collider other)
    {

        if (other.gameObject.tag == "Player")
        {
            endHandModel.SetActive(true);
            endHandTimeline.Play();
        }
    }
}
