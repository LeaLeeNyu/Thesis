using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

public class OpenEndRoomDoor : MonoBehaviour
{
    [SerializeField] private PlayableDirector playableDirector;

    private void OnEnable()
    {
        playableDirector.Play();
    }
}
