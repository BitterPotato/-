using UnityEngine;

public class FlockBehaviour : MonoBehaviour {
    struct Fish {
		public Vector3 position;
		public Vector3 velocity;
		public Vector4 color;
	};
    const int FISH_SIZE = 40;

    [System.Serializable]
    public class Cuboid
    {
        public Vector3 left_bottom_back;
        public Vector3 size;
    }

	public Mesh _InstanceMesh;
	public Material _InstanceMaterial;
    public ComputeShader _ComputeShader;

    public Color[] _ColorOffsets;
    public Cuboid[] _Cuboids;

    private int mInstanceCount = 60;
    private int mCachedInstanceCount = -1;

	private ComputeBuffer mFishBuffer;
	private ComputeBuffer mOutFishBuffer;
    private ComputeBuffer mComputeArgsBuffer;
	private ComputeBuffer mArgsBuffer;
	private uint[] mArgs = new uint[5] { 0, 0, 0, 0, 0 };

    void Start() {
		mArgsBuffer = new ComputeBuffer(1, mArgs.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
		InitFishBuffers();
	}

	void Update() {

		// Update starting position buffer
		if (mCachedInstanceCount != mInstanceCount)
			InitFishBuffers();
		else {
            UpdateFishBuffers();
        }

        Fish[] new_fishes = new Fish[mInstanceCount];
        mFishBuffer.GetData(new_fishes);

        // Render
        Graphics.DrawMeshInstancedIndirect(_InstanceMesh, 0, _InstanceMaterial, new Bounds(Vector3.zero, new Vector3(100.0f, 100.0f, 100.0f)), mArgsBuffer);
	}

    void OnDisable()
    {
        UninitBuffer(ref mFishBuffer);
        UninitBuffer(ref mOutFishBuffer);
        UninitBuffer(ref mComputeArgsBuffer);
        UninitBuffer(ref mArgsBuffer);
    }

    private void InitFishBuffers() {
		InitBuffer (ref mFishBuffer, mInstanceCount, FISH_SIZE);
        InitBuffer(ref mOutFishBuffer, mInstanceCount, FISH_SIZE);
        InitBuffer(ref mComputeArgsBuffer, 1, 1);

		// init buffer with random values
		Fish[] fishes = new Fish[mInstanceCount];
        System.Random random = new System.Random();
		for (int i=0; i < mInstanceCount; i++) {
            Fish fish = new Fish();
            Cuboid cuboid = _Cuboids[random.Next(_Cuboids.Length)];
            fish.position = new Vector3((float)random.NextDouble()* cuboid.size.x + cuboid.left_bottom_back.x,
                (float)random.NextDouble() * cuboid.size.y + cuboid.left_bottom_back.y,
                (float)random.NextDouble() * cuboid.size.z + cuboid.left_bottom_back.z);
            // fish.velocity
            fish.velocity = new Vector3(1.0f, 0.0f, 0.0f);
            fish.color = _ColorOffsets[random.Next(_ColorOffsets.Length)];

            fishes[i] = fish;
		}
		mFishBuffer.SetData(fishes);

        float[] args = new float[1];
        args[0] = 2.0f;
        mComputeArgsBuffer.SetData(args);

        _InstanceMaterial.SetBuffer("fishBuffer", mFishBuffer);

		// indirect args
		uint numIndices = (_InstanceMesh != null) ? (uint)_InstanceMesh.GetIndexCount(0) : 0;
		mArgs[0] = numIndices;
		mArgs[1] = (uint)mInstanceCount;
		mArgsBuffer.SetData(mArgs);

		mCachedInstanceCount = mInstanceCount;
	}

    private void UpdateFishBuffers()
    {
        // compute shader can have multiple kernels in a single file
        int kernelHandle = _ComputeShader.FindKernel("CSMain");

        // move data from CPU to GPU
        //_ComputeShader.SetFloat("ratio", 1.0f);
        //_ComputeShader.SetInt("groupSize", 15);
        //_ComputeShader.SetInt("groupNum", 4);
        //_ComputeShader.SetFloat("dtime", 0.4f);
        //_ComputeShader.SetFloat("sepe_weight", 0.1f);
        //_ComputeShader.SetFloat("cohe_weight", 5.0f);
        //_ComputeShader.SetFloat("align_weight", 1.0f);
        //_ComputeShader.SetFloat("change_weight", 0.1f);
        //_ComputeShader.SetFloat("max_velocity", 5.0f);

        _ComputeShader.SetBuffer(kernelHandle, "inputFishes", mFishBuffer);
        // TODO: set outFishBuffer 
        _ComputeShader.SetBuffer(kernelHandle, "outputFishes", mOutFishBuffer);
        _ComputeShader.SetBuffer(kernelHandle, "argsBuffer", mComputeArgsBuffer);
        _ComputeShader.Dispatch(kernelHandle, 60 / 4, 1, 1);

        //instanceMaterial.SetBuffer("fishBuffer", fishBuffer);

        Fish[] old_fishes = new Fish[mInstanceCount];
        mFishBuffer.GetData(old_fishes);

        Fish[] new_fishes = new Fish[mInstanceCount];
        mOutFishBuffer.GetData(new_fishes);

        // swap
        ComputeBuffer tempRefBuffer = mFishBuffer;
        mFishBuffer = mOutFishBuffer;
        mOutFishBuffer = tempRefBuffer;
    }

	// buffer operations
	private void InitBuffer(ref ComputeBuffer refBuffer, int instanceCount, int stride) {
		if (refBuffer != null)
			refBuffer.Release ();
		refBuffer = new ComputeBuffer (instanceCount, stride);
	}

	private void UninitBuffer(ref ComputeBuffer refBuffer) {
		if (refBuffer != null)
			refBuffer.Release ();
		refBuffer = null;
	}


}
