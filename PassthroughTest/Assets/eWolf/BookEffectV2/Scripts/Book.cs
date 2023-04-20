using eWolf.BookEffectV2.Interfaces;
using System;
using UnityEngine;

namespace eWolf.BookEffectV2
{
    public class Book : MonoBehaviour, IBookControl
    {
        public GameObject BookCoverAnimation;
        public GameObject BookCoverMesh;
        public Details Details = new Details();
        public GameObject PageAnimation;
        public GameObject PageMesh;
        private bool _bookOpen;

        public bool CanTurnPageBackWard
        {
            get
            {
                return IsBookOpen && !PageTurning && Details.StartingPage != 0;
            }
        }

        public bool CanTurnPageForward
        {
            get
            {
                return IsBookOpen && !PageTurning && Details.CanTurnPage();
            }
        }

        public Details GetDetails
        {
            get
            {
                return Details;
            }
        }

        public bool IsBookOpen
        {
            get
            {
                return _bookOpen;
            }
        }

        private Animator _bookAnimator { get; set; }
        private Material InsideBackCover { get; set; }
        private Material InsideFrontCover { get; set; }
        private Animator PageAnimator { get; set; }
        private Material PageBack { get; set; }
        private Material PageFront { get; set; }
        private bool PageTurnedBack { get; set; }
        private bool PageTurning { get; set; }

        public void CloseBook()
        {
            HidePage();
            _bookOpen = false;
            _bookAnimator.SetBool("Open", false);
        }

        public void OpenBook()
        {
            InsideFrontCover.mainTexture = Details.LeftPage();
            InsideBackCover.mainTexture = Details.RightPage();
            _bookOpen = true;
            _bookAnimator.SetBool("Open", true);
        }

        public void OpenBookAtPage(int pageIndex)
        {
            Details.StartingPage = pageIndex;
            OpenBook();
        }

        public void SetSpeed(float speed)
        {
            _bookAnimator.speed = speed;
            PageAnimator.speed = speed;
        }

        public void Start()
        {
            _bookAnimator = BookCoverAnimation.GetComponent<Animator>();
            PageAnimator = PageAnimation.GetComponent<Animator>();
            PopulateMaterials();
            SetSpeed(2);
            HidePage();
        }

        public void TurnPage()
        {
            ShowPage();

            PageTurning = true;
            PageAnimator.SetBool("TurnPageNormal", true);
            PageAnimator.SetBool("TurnPageBackNormal", false);

            InsideFrontCover.mainTexture = Details.LeftPage();
            PageFront.mainTexture = Details.RightPage();
            PageBack.mainTexture = Details.NextLeftPage();
            InsideBackCover.mainTexture = Details.NextRightPage();
        }

        public void TurnPageBack()
        {
            ShowPage();
            PageTurnedBack = true;
            PageAnimator.SetBool("TurnPageNormal", false);
            PageAnimator.SetBool("TurnPageBackNormal", true);

            Details.TurnPageBack();
            InsideFrontCover.mainTexture = Details.LeftPage();
            PageFront.mainTexture = Details.RightPage();
            PageBack.mainTexture = Details.NextLeftPage();
            InsideBackCover.mainTexture = Details.NextRightPage();
        }

        public void Update()
        {
            if (Input.GetKeyDown("c"))
            {
                string screenshotFilename;
                DateTime td = System.DateTime.Now;
                screenshotFilename = "..//ScreenShots//SS - " + td.ToString("yyyy MM dd-HH-mm-ss-ffff") + ".png";
                ScreenCapture.CaptureScreenshot(screenshotFilename);
                Debug.Log("Taken Snap Shot." + td.ToString("yyyy MM dd-HH-mm-ss-ffff"));
            }

            if (PageTurning || PageTurnedBack)
            {
                AnimatorStateInfo currentBaseState = PageAnimator.GetCurrentAnimatorStateInfo(0);
                if (currentBaseState.IsName("WaitBackTurn"))
                {
                    if (PageTurning)
                    {
                        PageTurning = false;
                        Details.TurnPage();
                        HidePage();
                        PageAnimator.SetBool("TurnPageNormal", false);

                        InsideFrontCover.mainTexture = Details.LeftPage();
                    }
                }
                if (currentBaseState.IsName("WaitTurnMid"))
                {
                    if (PageTurnedBack)
                    {
                        PageTurnedBack = false;

                        HidePage();
                        PageAnimator.SetBool("TurnPageBackNormal", false);
                        InsideBackCover.mainTexture = Details.RightPage();
                    }
                }
            }
        }

        private void HidePage()
        {
            PageMesh.SetActive(false);
        }

        private void PopulateMaterials()
        {
            foreach (Material material in BookCoverMesh.GetComponent<Renderer>().materials)
            {
                if (material.name == "Cover (Instance)")
                {
                }
                if (material.name == "InsideBackCover (Instance)")
                {
                    InsideBackCover = material;
                }
                if (material.name == "InsideFrontCover (Instance)")
                {
                    InsideFrontCover = material;
                }
            }

            InsideFrontCover.mainTexture = Details.LeftPage();
            InsideBackCover.mainTexture = Details.RightPage();

            foreach (Material material in PageMesh.GetComponent<Renderer>().materials)
            {
                Debug.Log(material.name);
                if (material.name == "PageFront (Instance)")
                {
                    PageFront = material;
                }

                if (material.name == "PageBack (Instance)")
                {
                    PageBack = material;
                }
            }

            PageFront.mainTexture = Details.RightPage();
            PageBack.mainTexture = Details.NextLeftPage();
        }

        private void ShowPage()
        {
            PageMesh.SetActive(true);
        }
    }
}