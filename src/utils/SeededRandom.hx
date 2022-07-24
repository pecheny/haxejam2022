package utils;
class SeededRandom implements Random {
        var seed:Float;
        public function new (seed)
            this.seed = seed;

        function getSeed():Float return seed;
        function setSeed(seed:Float):Void this.seed = seed;

        public static inline function nextRandom(seed:Float):{number:Float, nextSeed:Float} {
            var nextSeed = (seed * 9301 + 49297) % 233280;
            return {
                number: nextSeed / 233280.0,
                nextSeed: nextSeed,
            };
        }

        public function random():Float {
            var r = nextRandom(getSeed());
            setSeed(r.nextSeed);
            return r.number;
        }

        public inline function randomInt(n:Int):Int {
            return Std.int(random() * n);
        }

        public inline function randomRange(min:Int, max:Int):Int {
            return min + randomInt(max - min + 1);
        }

//        public inline function choose<T>(arr:_const.Array<T>):T {
//            return arr[randomInt(arr.length)];
//        }

//        public function weightedRandom<T>(items:Iterable<T>, getWeightFunc:T->Weight):T {
//            var totalWeight = 0;
//            for (i in items) {
//                totalWeight += cast getWeightFunc(i);
//            }
//            //trace("totalWeight = " + totalWeight);
//            var result:T = null;
//            var rnd = randomInt(totalWeight);
//            var accumWeight = 0;
//            //trace("rnd = " + rnd);
//            for (i in items) {
//                if (accumWeight > rnd)
//                    break;
//                result = i;
//                accumWeight += cast getWeightFunc(i);
//            }
//            if (result == null)
//                throw "Wrong";
//            return result;
//        }
//
//        public inline function deviatedRandom(expectation: Int, deviation:Float) : Int {
//            var min = expectation - Math.round(expectation*deviation);
//            var max = expectation + Math.round(expectation*deviation);
//            return randomRange(min, max);
//        }
//

}


interface Random {
    function random():Float;

}
