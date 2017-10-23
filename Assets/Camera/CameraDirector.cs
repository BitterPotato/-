using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraDirector : MonoBehaviour {

    public GameObject mainCameraRigPrefab;
    // Camera points.
    public Transform[] cameraPoints;

    CameraSwitcher mainCameraSwitcher;

    // Use this for initialization
    void Start () {
        var cameraRig = (GameObject)Instantiate(mainCameraRigPrefab);
        mainCameraSwitcher = cameraRig.GetComponentInChildren<CameraSwitcher>();
    }
	
	// Update is called once per frame
	void Update () {
		
	}
    
    public void SwitchCamera(int index)
    {
        if (mainCameraSwitcher)
            mainCameraSwitcher.ChangePosition(cameraPoints[index], true);
    }

    public void StartAutoCameraChange()
    {
        if (mainCameraSwitcher)
            mainCameraSwitcher.StartAutoChange();
    }

    public void StopAutoCameraChange()
    {
        if (mainCameraSwitcher)
            mainCameraSwitcher.StopAutoChange();
    }

    // declare those animate event to avoid run warning
    public void StartMusic()
    {
    }

    public void ActivateProps()
    {
    }

    public void FastForward(float second)
    {
    }

    void FastForwardAnimator(Animator animator, float second, float crossfade)
    {
    }

    public void EndPerformance()
    {
    }
}
