using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HandAnimationSwitch : MonoBehaviour
{
    [SerializeField] private Animator handAnimator;

    [SerializeField] private GameObject pills;
    [SerializeField] private GameObject book;
    [SerializeField] private GameObject photo;

    private void OnEnable()
    {
        ColliderPlayableDirector.pillsToBook += PillsToBookAni;
        ColliderPlayableDirector.bookToPhoto += BookToPhotoAni;
        ShowEndroom.photoOpen += PhotoOpenAni;

    }

    private void OnDisable()
    {
        ColliderPlayableDirector.pillsToBook -= PillsToBookAni;
        ColliderPlayableDirector.bookToPhoto -= BookToPhotoAni;
        ShowEndroom.photoOpen -= PhotoOpenAni;
    }

    private void PillsToBookAni()
    {
        handAnimator.SetBool("PillsToBook",true);
        pills.SetActive(false);
        book.SetActive(true);
    }

    private void BookToPhotoAni()
    {
        handAnimator.SetBool("BookToPhoto", true);
        book.SetActive(false);
        photo.SetActive(true);
    }

    private void PhotoOpenAni()
    {
        handAnimator.SetBool("PhotoOpen", true);
        photo.SetActive(false);
    }


}
