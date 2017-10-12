using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Flock : MonoBehaviour {
	public ComputeShader shader;

	void RunShader() {
		// compute shader can have multiple kernels in a single file
		int kernelHandle = shader.FindKernel ("CSMain");

		// init data set
		RenderTexture tex = new RenderTexture(256, 256, 24);
		tex.enableRandomWrite = true;
		tex.Create ();

		// move data from CPU to GPU
		shader.SetTexture (kernelHandle, "Result", tex);
		shader.Dispatch (kernelHandle, 256 / 8, 256 / 8, 1);
	}
	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
