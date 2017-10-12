using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DepthCamera : PostEffectsBase {

	public Shader outlineShader;
	private Material outlineMaterial = null;
	public Material material {
		get {
			outlineMaterial = CheckShaderAndCreateMaterial (outlineShader, outlineMaterial);
			return outlineMaterial;
		}
	}

//	[Range(0.0f, 1.0f)]
//	public float estimateDepthFrom = 0.2f;
//	[Range(0.0f, 1.0f)]
//	public float estimateDepthTo = 0.8f;
//
//	public float edgeWidthFrom = 0.1f;
//	public float edgeWidthTo = 0.5f;

//	[Range]

	void onRenderImage(RenderTexture src, RenderTexture dest) {
		if(material != null) {
//			material
			Graphics.Blit(src, dest, material);
		}
	}
	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
