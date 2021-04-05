package;

import assets.LoadableAsset;

class KeyedResource<T:LoadableAsset<Dynamic>>
{
	public var key:NamespacedKey;

	private var asset:T;

	public function new(key:NamespacedKey)
	{
		this.key = key;
	}

	public function getAsset()
	{
		return this.asset;
	}
}
