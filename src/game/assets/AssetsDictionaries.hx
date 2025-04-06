package assets;

/**
	Access to slice names present in Aseprite files (eg. `trace( tiles.fxStar )` ).
	This class only provides access to *names* (ie. String). To get actual h2d.Tile, use Assets class.

	Examples:
	```haxe
	Assets.tiles.getTile( AssetsDictionaries.tiles.mySlice );
	Assets.tiles.getTile( D.tiles.mySlice ); // uses "D" alias defined in "import.hx" file
	```
**/
class AssetsDictionaries {
	public static var tiles = dn.heaps.assets.Aseprite.getDict( hxd.Res.atlas.tiles );
	//public static var particles = dn.heaps.assets.Atlas.getDict( hxd.Res.atlas.particles );
	public static var characters  = dn.heaps.assets.Aseprite.getDict( hxd.Res.atlas.characters );
	public static var icons = dn.heaps.assets.Aseprite.getDict( hxd.Res.atlas.icons );

}
