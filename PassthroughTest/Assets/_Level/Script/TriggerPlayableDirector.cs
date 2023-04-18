using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

public class TriggerPlayableDirector : MonoBehaviour
{
    [SerializeField] private PlayableDirector playableDirector;

    public void PlayTimeline()
    {
        playableDirector.Play();
    }
}
