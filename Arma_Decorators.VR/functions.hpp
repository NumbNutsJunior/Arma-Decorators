#define POST_INIT postInit = 1;

class CfgFunctions {

	class life {

        class Decorators {
            file = "decorators";

            class trackCalls {};
            class trackRuntime {};

            class initDecorators {POST_INIT};
        };

		class ClientConfig {
			file = "config";
		};

		class ClientFunctions {
			file = "functions";

            class composeHeader {};
            class function_01 { decorators[] = {"trackRuntime", "trackCalls"}; };
            class function_02 { decorators[] = {"trackRuntime", "trackCalls"}; };
            class function_03 { decorators[] = {"trackRuntime", "trackCalls"}; };
		};

		class HUDFunctions {
			file = "hud\functions";
		};
	};
};
