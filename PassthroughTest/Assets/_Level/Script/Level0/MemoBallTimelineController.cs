using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

public class MemoBallTimelineController : MonoBehaviour
{
    [SerializeField] private PlayableDirector MemoBallTimeline;
    public void StartMemoBallTimeline()
    {
        MemoBallTimeline.Play();
    }
}
