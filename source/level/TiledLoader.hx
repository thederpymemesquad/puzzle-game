package level;

import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import states.PlayState;

class TiledLoader
{
	public static function loadLevel(level:NamespacedKey, delegate:PlayState)
	{
		var map = new TiledMap(AssetHelper.getLevelAsset(level));

		delegate.acceptLevelProperties(map.properties);

		for (layer in map.layers)
		{
			if (Std.is(layer, TiledTileLayer))
			{
				delegate.acceptLevelTileLayer(cast layer);
			}
			else if (Std.is(layer, TiledObjectLayer))
			{
				var oLayer:TiledObjectLayer = cast layer;
				for (obj in oLayer.objects)
				{
					var x:Int = obj.x;
					var y:Int = obj.y;

					if (obj.gid != -1)
					{
						y -= oLayer.map.getGidOwner(obj.gid).tileHeight;
					}

					delegate.acceptLevelObject(obj, x, y, oLayer.objects);
				}
			}
		}
	}
}
