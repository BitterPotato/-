using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraDirector : MonoBehaviour {

    public GameObject musicPlayerPrefab;
    public GameObject mainCameraRigPrefab;
    // Camera points.
    public Transform[] cameraPoints;

    CameraSwitcher mainCameraSwitcher;
    GameObject musicPlayer;

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

        if(musicPlayer == null)
            // Notice: it seem that when GameObject once cloned in the scene, the audio will play
            musicPlayer = (GameObject)Instantiate(musicPlayerPrefab);
        foreach (var source in musicPlayer.GetComponentsInChildren<AudioSource>())
            source.Play();
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
