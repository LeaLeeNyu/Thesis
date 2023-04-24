using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

public class ActiveBeauty : MonoBehaviour
{
    [SerializeField] private GameObject avatarOne;
    [SerializeField] private GameObject avatarTwo;
    [SerializeField] private GameObject avatarThree;

    [SerializeField] private GameObject skySphere;
    [SerializeField] private GameObject alienPlanet;
    [SerializeField] private PlayableDirector door;

    private bool isOpened = false;

    private void Update()
    {
        if(avatarOne.activeSelf 
            && avatarTwo.activeSelf 
            && avatarThree.activeSelf && !isOpened)
        {
            skySphere.SetActive(false);
            alienPlanet.SetActive(true);
            door.Play();
            isOpened = true;
        }
    }
}
