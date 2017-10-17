using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NoiseTerrain : MonoBehaviour {

    public GameObject _PlaneObject;

    // controll the swing of noise
    public int _HeightScale = 5;
    // controll the num of lattice
    public float _DetailScale = 5.0f;

    public int _XTileNum = 5;
    public int _ZTileNum = 5;

    private int mPlaneSize = 10;
	// Use this for initialization
	void Start () {
        for(int x = 0; x < _XTileNum; x++)
        {
            for(int z = 0; z < _ZTileNum; z++)
            {
                GameObject tile = Instantiate(_PlaneObject);
                generateMesh(ref tile, new Vector3(x * mPlaneSize, 0, z * mPlaneSize));
            }
        }
	}

    // use transform to move the tile
    void generateMesh(ref GameObject tile, Vector3 transform)
    {
        Mesh mesh = tile.GetComponent<MeshFilter>().mesh;
        Vector3[] vertices = mesh.vertices;
        for (int i = 0; i < vertices.Length; i++)
        {
            vertices[i].y = Mathf.PerlinNoise((vertices[i].x + transform.x) / _DetailScale, (vertices[i].z + transform.z)/ _DetailScale) * _HeightScale;
        }

        mesh.vertices = vertices;
        mesh.RecalculateBounds();
        mesh.RecalculateNormals();
        //this.gameObject.AddComponent<MeshCollider>();
    }
	
	// Update is called once per frame
	void Update () {
        //Mesh mesh = this.GetComponent<MeshFilter>().mesh;
        //Vector3[] vertices = mesh.vertices;
        //for (int i = 0; i < vertices.Length; i++)
        //{
        //    vertices[i].y = Mathf.PerlinNoise(vertices[i].x / detailScale, vertices[i].z / detailScale) * heightScale;
        //}

        //mesh.vertices = vertices;
        //mesh.RecalculateBounds();
        //mesh.RecalculateNormals();
        //this.gameObject.AddComponent<MeshCollider>();
    }
}
