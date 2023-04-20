using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

public class ColliderPlayableDirector : MonoBehaviour
{
    [SerializeField] private GameObject book;
    [SerializeField] private PlayableDirector playableDirector;

    private bool bookIsOpen = false;

    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.tag == "Player" && !bookIsOpen)
        {
            book.SetActive(true);
            playableDirector.Play();
            bookIsOpen = true;
        }
    }
}
