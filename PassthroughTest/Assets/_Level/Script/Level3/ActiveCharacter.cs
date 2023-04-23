using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ActiveCharacter : MonoBehaviour
{
    [SerializeField] private GameObject hi;
    [SerializeField] private GameObject watering;
    [SerializeField] private GameObject sitting;

    private void OnEnable()
    {
        Raycast.ActiveHi += ShowHi;
        Raycast.ActiveWater += ShowWatering;
        Raycast.ActiveSit += ShowSit;
    }

    private void OnDisable()
    {
        Raycast.ActiveHi -= ShowHi;
        Raycast.ActiveWater -= ShowWatering;
        Raycast.ActiveSit -= ShowSit;
    }

    private void ShowHi()
    {
        hi.SetActive(true);
    }

    void ShowWatering()
    {
        watering.SetActive(true);
    }

    private void ShowSit()
    {
        sitting.SetActive(true);
    }
}
