Hooks = {}
Hooks._prehooks = {}
Hooks._posthooks = {}

function Hooks:PreHook(class, func_name, hook_id, hook_func)
    if not self._prehooks[class] then
        self._prehooks[class] = {}
    end

    if not self._prehooks[class][func_name] then
        self._prehooks[class][func_name] = {}
        local old_func = class[func_name]
        class[func_name] = function(...)
            for id, f in pairs(self._prehooks[class][func_name]) do
                f(...)
            end
            return old_func(...)
        end
    end

    self._prehooks[class][func_name][hook_id] = hook_func

end

function Hooks:PostHook(class, func_name, hook_id, hook_func)
    if not self._posthooks[class] then
        self._posthooks[class] = {}
    end

    if not self._posthooks[class][func_name] then
        self._posthooks[class][func_name] = {}
        local old_func = class[func_name]
        class[func_name] = function(...)
            local result = old_func(...)
            for id, f in pairs(self._posthooks[class][func_name]) do
                f(...)
            end
            return result
        end
    end

    self._posthooks[class][func_name][hook_id] = hook_func

end
