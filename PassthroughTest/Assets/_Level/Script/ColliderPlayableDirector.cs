using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.Playables;

public class ColliderPlayableDirector : MonoBehaviour
{
    [SerializeField] private GameObject activeObject;
    [SerializeField] private PlayableDirector playableDirector;

    public string activeObjectName; 
    public static UnityAction pillsToBook = delegate { };
    public static UnityAction bookToPhoto = delegate { };

    private bool animationPlayerd = false;

    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.tag == "Player" && !animationPlayerd)
        {
            activeObject.SetActive(true);
            playableDirector.Play();
            animationPlayerd = true;

            if(activeObjectName == "book")
            {
                pillsToBook.Invoke();
                Debug.Log("handbook");
            }else if(activeObjectName == "photo")
            {
                bookToPhoto.Invoke();
            }
        }
    }
}
